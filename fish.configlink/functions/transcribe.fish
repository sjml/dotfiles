function transcribe
		set locale ""

		while test (count $argv) -gt 0
				switch $argv[1]
						case '-l' '--locale'
								if test (count $argv) -lt 2
										echo "Error: --locale requires a value"
										return 1
								end
								set locale $argv[2]
								set -e argv[1..2]
						case '*'
								break
				end
		end

		if test (count $argv) -eq 0
				echo "Usage: transcribe [-l <locale>] <file1> [file2 ...]"
				return 1
		end

		for file in $argv
				if not test -f "$file"
						echo "File not found: $file"
						continue
				end

				set base (string replace -r '\.[^.]+$' '' "$file")
				set out "$base".srt

				echo "Processing $file → $out"

				if test -n "$locale"
						yap transcribe --srt -o "$out" -l "$locale" "$file"
				else
						yap transcribe --srt -o "$out" "$file"
				end
		end
end
