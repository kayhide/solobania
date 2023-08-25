import SlButton from "@shoelace-style/shoelace/dist/react/button/index.js";
import SlButtonGroup from "@shoelace-style/shoelace/dist/react/button-group/index.js";
import SlCard from "@shoelace-style/shoelace/dist/react/card/index.js";
import SlInput from "@shoelace-style/shoelace/dist/react/input/index.js";
import SlOption from "@shoelace-style/shoelace/dist/react/option/index.js";
import SlSelect from "@shoelace-style/shoelace/dist/react/select/index.js";

import { element } from "../React.Basic/index.js";

var button = element(SlButton);
var button_group = element(SlButtonGroup);
var card = element(SlCard);
var input = element(SlInput);
var select = element(SlSelect);
var option = element(SlOption);

export { button, button_group, card, input, select, option };
