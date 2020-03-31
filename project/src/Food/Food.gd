extends Node
class_name Food

# Emitted when this food is fully processed
# warning-ignore:unused_signal
signal processed(food)

var enabled := true
