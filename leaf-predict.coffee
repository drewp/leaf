Polymer
  is: "leaf-predict"
  properties:
    previous: {notify: true, observer: 'previousChanged'}
  ready: () ->
    @graph = new Rickshaw.Graph(
      element: @$.chart
      width: 900
      height: 200
      min: 0
      max: 12
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
    @graph.window.xMin = +new Date() - 86400 * 1 * 1000
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
    @graph.series[0].data = seriesData
    @graph.render()
