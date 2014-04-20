Polymer "leaf-predict", {
  ready: () ->
    @graph = new Rickshaw.Graph(
      element: @$.chart
      width: 900
      height: 200
      stroke: true
      strokeWidth: 3
      renderer: "line"
      interpolation: "linear"
      xScale: d3.time.scale()
      yScale: d3.scale.linear()
      series: [
        {
          color: "steelblue"
          # slider needs to see some data
          data: [{x:0,y:0}]
        }
      ]
    )
    @graph.render()

    xAxis = new Rickshaw.Graph.Axis.X(
      graph: @graph
      tickFormat: @graph.x.tickFormat()
    )
    xAxis.render()
    
    yAxis = new Rickshaw.Graph.Axis.Y(graph: @graph)
    yAxis.render()
    
    slider = new Rickshaw.Graph.RangeSlider.Preview(
      graph: @graph
      element: @$.slider
    )
    
  previousChanged: () ->
    pts = @previous
    seriesData = ({x: +new Date(row[0]), y: parseFloat(row[1])} for row in pts)
    console.log(seriesData[seriesData.length-1])
    @graph.series[0].data = seriesData
    @graph.render()
}