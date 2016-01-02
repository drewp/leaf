Polymer
  is: "leaf-predict"
  properties:
    previous: {notify: true, observer: 'previousChanged'}
    layout: {value: "full", notify: true, observer: 'initGraph'}
  ready: () ->
    #@initGraph()
  initGraph: () ->
    @$.chart.removeChild(c) for c in @$.chart.children
    @$.slider.removeChild(c) for c in @$.slider.children

    @graph = new Rickshaw.Graph(
      element: @$.chart
      width: (if @layout == 'full' then 900 else 200)
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

    if @layout == 'full'
      slider = new Rickshaw.Graph.RangeSlider.Preview(
        graph: @graph
        element: @$.slider
      )

    @graph.updateCallbacks.push(() => @patchStyle())

  patchStyle: () ->
    styleFix = document.createElement('style')
    styleFix.innerText = '.domain { fill: none; stroke: none; }'
    svgNode = @$.chart.firstChild
    svgNode.insertBefore(styleFix, svgNode.firstChild)
    
  previousChanged: () ->
    pts = @previous
    seriesData = ({x: +new Date(row[0]), y: parseFloat(row[1])} for row in pts)
    @graph.series[0].data = seriesData
    @graph.render()
