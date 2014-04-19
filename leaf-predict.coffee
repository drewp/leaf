Polymer "leaf-predict", {
  ready: () ->
    seriesData = [[], []]
    random = new Rickshaw.Fixtures.RandomData(1500000)
    i = 0

    while i < 900
      random.addData seriesData
      i++
    chartElem = @$.chart
    graph = new Rickshaw.Graph(
      element: chartElem
      width: 960
      height: 500
      stroke: true
      strokeWidth: 0.5
      renderer: "area"
      xScale: d3.time.scale()
      yScale: d3.scale.sqrt()
      series: [
        {
          color: "steelblue"
          data: seriesData[0]
        }
        {
          color: "#99d4ee"
          data: seriesData[1]
        }
      ]
    )
    graph.render()
    xAxis = new Rickshaw.Graph.Axis.X(
      graph: graph
      tickFormat: graph.x.tickFormat()
    )
    xAxis.render()
    yAxis = new Rickshaw.Graph.Axis.Y(graph: graph)
    yAxis.render()
    slider = new Rickshaw.Graph.RangeSlider.Preview(
      graph: graph
      element: @$.slider
    )
}