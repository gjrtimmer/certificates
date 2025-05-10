def dict_defaults(input_dict, defaults):
    """apply defaults to every key of the input dict"""
    return {k: {**defaults, **v} for (k, v) in input_dict.items()}


class FilterModule(object):
    """my custom filters"""

    def filters(self):
        """Return the filter list."""
        return {
            "dict_defaults": dict_defaults
        }
    