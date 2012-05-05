d3.json(curators_json_path, function(json) {

  var width = 600,
      height = 600,
      format = d3.format(",d");

  var pack = d3.layout.pack()
      .size([width - 4, height - 4])
      .value(function(d) { return d.size; });

  var vis = d3.select("#viz-curators-full").append("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("class", "pack")
    .append("g")
      .attr("transform", "translate(2, 2)");

  var node = vis.data([json]).selectAll("#viz-curators-full g.node")
      .data(pack.nodes)
    .enter().append("g")
      .attr("class", function(d) { return d.children ? "node" : "leaf node"; })
      .attr("transform", function(d) { return "translate(" + d.x + "," + d.y + ")"; });

  node.append("title")
      .text(function(d) { return d.name + (d.children ? "" : ": " + format(d.size)); });

  node.append("circle")
      .attr("r", function(d) { return d.r; });

  node.filter(function(d) { return !d.children; }).append("text")
      .attr("text-anchor", "middle")
      .attr("dy", ".3em")
      .text(function(d) { return d.name.substring(0, d.r / 3); });
});
