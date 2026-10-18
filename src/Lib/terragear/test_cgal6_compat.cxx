#include <cmath>
#include <cstdlib>
#include <iostream>
#include <vector>

#include "tg_misc.hxx"
#include "tg_nodes.hxx"
#include "tg_polygon.hxx"

namespace {

void require(bool condition, const char* message)
{
    if (!condition) {
        std::cerr << message << '\n';
        std::exit(EXIT_FAILURE);
    }
}

tgContour make_contour(const std::vector<SGGeod>& points)
{
    tgContour contour;
    for (const auto& point : points) {
        contour.AddNode(point);
    }
    return contour;
}

double triangle_area(const tgTriangle& triangle)
{
    const SGGeod& a = triangle.GetNode(0);
    const SGGeod& b = triangle.GetNode(1);
    const SGGeod& c = triangle.GetNode(2);
    return std::abs((a.getLongitudeDeg() * (b.getLatitudeDeg() - c.getLatitudeDeg()) +
                     b.getLongitudeDeg() * (c.getLatitudeDeg() - a.getLatitudeDeg()) +
                     c.getLongitudeDeg() * (a.getLatitudeDeg() - b.getLatitudeDeg())) /
                    2.0);
}

double triangulated_area(tgPolygon& polygon)
{
    polygon.Tesselate();
    double area = 0.0;
    for (unsigned int i = 0; i < polygon.Triangles(); ++i) {
        const double current = triangle_area(polygon.GetTriangle(i));
        require(current > 0.0, "triangulation returned a degenerate triangle");
        area += current;
    }
    return area;
}

void test_triangulation()
{
    const tgContour square = make_contour({
        SGGeod::fromDeg(0.0, 0.0),
        SGGeod::fromDeg(4.0, 0.0),
        SGGeod::fromDeg(4.0, 4.0),
        SGGeod::fromDeg(0.0, 4.0),
    });

    tgPolygon solid;
    solid.AddContour(square);
    require(std::abs(triangulated_area(solid) - 16.0) < 1e-9,
            "square triangulation did not preserve its area");

    tgPolygon with_hole;
    with_hole.AddContour(square);
    with_hole.AddContour(make_contour({
        SGGeod::fromDeg(1.0, 1.0),
        SGGeod::fromDeg(1.0, 3.0),
        SGGeod::fromDeg(3.0, 3.0),
        SGGeod::fromDeg(3.0, 1.0),
    }));
    require(std::abs(triangulated_area(with_hole) - 12.0) < 1e-9,
            "polygon-with-hole triangulation did not preserve its area");
}

void test_spatial_queries()
{
    TGNodes nodes;
    nodes.unique_add(SGGeod::fromDegM(0.0, 0.0, 10.0));
    nodes.unique_add(SGGeod::fromDegM(1.0, 1.0, 20.0));
    nodes.unique_add(SGGeod::fromDegM(3.0, 3.0, 30.0));
    nodes.init_spacial_query();

    std::vector<SGGeod> points;
    require(nodes.get_geod_inside(SGGeod::fromDeg(-0.1, -0.1),
                                  SGGeod::fromDeg(1.1, 1.1), points),
            "spatial query failed");
    require(points.size() == 2, "spatial query returned an unexpected number of points");

    std::vector<TGNode*> matched_nodes;
    require(nodes.get_nodes_inside(SGGeod::fromDeg(-0.1, -0.1),
                                  SGGeod::fromDeg(1.1, 1.1), matched_nodes),
            "node spatial query failed");
    require(matched_nodes.size() == 2, "node spatial query returned an unexpected number of nodes");
}

void test_segment_intersection()
{
    SGGeod result;
    require(intersection(SGGeod::fromDeg(0.0, 0.0), SGGeod::fromDeg(2.0, 2.0),
                         SGGeod::fromDeg(0.0, 2.0), SGGeod::fromDeg(2.0, 0.0), result),
            "crossing segments were not reported as intersecting");
    require(std::abs(result.getLongitudeDeg() - 1.0) < 1e-9 &&
                std::abs(result.getLatitudeDeg() - 1.0) < 1e-9,
            "segment intersection returned incorrect coordinates");
    require(!intersection(SGGeod::fromDeg(0.0, 0.0), SGGeod::fromDeg(1.0, 0.0),
                          SGGeod::fromDeg(2.0, 0.0), SGGeod::fromDeg(3.0, 0.0), result),
            "disjoint segments were reported as intersecting");
}

} // namespace

int main()
{
    test_triangulation();
    test_spatial_queries();
    test_segment_intersection();
    return EXIT_SUCCESS;
}
