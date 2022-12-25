const fetch = require("node-fetch");
const csv = require("csv-parser");
const { pipeline } = require("stream");
const { plot, xlabel, ylabel, title } = require("plotly")(
  "username",
  "api_key"
);
import { map, groupBy, meanBy, filter } from "ramda";

// Load data from US Bureau of Labor Statistics
const dataUrl =
  "https://download.bls.gov/pub/time.series/cu/cu.data.1.AllItems";

function* filterBySeriesId(seriesId, source) {
  yield* filter((row) => row.seriesId === seriesId, source);
}

function* averageByYear(source) {
  yield* map(
    (group) => ({ year: group[0].year, value: meanBy(group, "value") }),
    groupBy((row) => row.month.slice(0, 4), source)
  );
}

function* averageByMonth(source) {
  yield* map(
    (group) => ({ month: group[0].month, value: meanBy(group, "value") }),
    groupBy((row) => row.month, source)
  );
}

function* toPlotlyData(source) {
  yield* map((row) => ({ x: row.year, y: row.value }), source);
}

pipeline(
  fetch(dataUrl).then((res) => res.body),
  csv({ separator: "\t" }),
  filterBySeriesId,
  averageByYear,
  averageByMonth,
  toPlotlyData
)
  .then((data) =>
    plot(data, {
      xaxis: {
        type: "category",
        title: "Year",
      },
      yaxis: {
        type: "linear",
        title: "Inflation (percentage)",
      },
      title: "US Inflation, 1914-2022",
    })
  )
  .catch((error) => console.error(error));
