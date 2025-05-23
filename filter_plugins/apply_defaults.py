import copy


def mergedicts(dict1, dict2):
    for k in set(dict1.keys()).union(dict2.keys()):
        if k in dict1 and k in dict2:
            if isinstance(dict1[k], dict) and isinstance(dict2[k], dict):
                yield (k, dict(mergedicts(dict1[k], dict2[k])))
            else:
                # If one of the values is not a dict,
                # you can't continue merging it.
                # Value from second dict overrides one in first and we move on.
                yield (k, dict2[k])
                # Alternatively, replace this with exception raiser
                # to alert you of value conflicts
        elif k in dict1:
            yield (k, dict1[k])
        else:
            yield (k, dict2[k])


def apply_defaults(input_dict, defaults):
    res = []
    for e in input_dict:
        elm = copy.deepcopy(defaults)
        elm = dict(mergedicts(elm, e))
        res.append(elm)
    return res


class FilterModule(object):
    def filters(self):
        return {
            "apply_defaults": apply_defaults
        }
