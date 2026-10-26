#!/usr/bin/env bash
# Duplicates copy-mode-vi bindings onto the Cyrillic letters at the same
# physical keys, so copy mode works in the Russian (ЙЦУКЕН) layout.
set -euo pipefail

TABLE="copy-mode-vi"

declare -A CYRILLIC_FOR=(
	[q]=й [w]=ц [e]=у [r]=к [t]=е [y]=н [u]=г [i]=ш [o]=щ [p]=з
	[a]=ф [s]=ы [d]=в [f]=а [g]=п [h]=р [j]=о [k]=л [l]=д
	[z]=я [x]=ч [c]=с [v]=м [b]=и [n]=т [m]=ь
	[Q]=Й [W]=Ц [E]=У [R]=К [T]=Е [Y]=Н [U]=Г [I]=Ш [O]=Щ [P]=З
	[A]=Ф [S]=Ы [D]=В [F]=А [G]=П [H]=Р [J]=О [K]=Л [L]=Д
	[Z]=Я [X]=Ч [C]=С [V]=М [B]=И [N]=Т [M]=Ь
	['\;']=ж [':']=Ж [',']=б ['\{']=Х ['\}']=Ъ
)

BINDING_PATTERN="^bind-key( -r)? -T ${TABLE} ([^ ]+) +(.*)$"

bindings_file=$(mktemp)
trap 'rm -f "$bindings_file"' EXIT

while IFS= read -r line; do
	[[ $line =~ $BINDING_PATTERN ]] || continue

	repeat_flag=${BASH_REMATCH[1]}
	key=${BASH_REMATCH[2]}
	command=${BASH_REMATCH[3]}

	[[ -v CYRILLIC_FOR[$key] ]] || continue

	echo "bind-key${repeat_flag} -T ${TABLE} ${CYRILLIC_FOR[$key]} ${command}" >>"$bindings_file"
done < <(tmux list-keys -T "$TABLE")

tmux source-file "$bindings_file"
