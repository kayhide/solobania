import "@fortawesome/fontawesome-free/js/fontawesome.js";
import "@fortawesome/fontawesome-free/js/solid.js";
import "@fortawesome/fontawesome-free/js/regular.js";

import "@shoelace-style/shoelace/dist/themes/light.css";
import { setBasePath } from "@shoelace-style/shoelace/dist/utilities/base-path";
setBasePath("/dist/shoelace");

import "./index.css";

import { main } from "../output/Main/index.js";
main();
