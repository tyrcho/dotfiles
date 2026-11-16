# Deep-merge a list of JSON objects, later ones win (jq -s -f merge-settings.jq a.json b.json ...).
# Objects merge key by key. Arrays (hook groups, permissions) are joined and
# de-duplicated keeping order, so re-merging the same files is a no-op.

def uniq_keep_order: reduce .[] as $x ([]; if any(.[]; . == $x) then . else . + [$x] end);

def deep_merge($a; $b):
  if ($a | type) == "object" and ($b | type) == "object" then
    reduce ($b | keys_unsorted[]) as $k ($a; .[$k] = deep_merge($a[$k]; $b[$k]))
  elif ($a | type) == "array" and ($b | type) == "array" then
    $a + $b | uniq_keep_order
  elif $b == null then $a
  else $b
  end;

reduce .[] as $doc ({}; deep_merge(.; $doc))
