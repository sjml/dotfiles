function transcribe
		if test (count $argv) -eq 0
				echo "Usage: transcribe <file1> [file2 ...]"
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
				yap transcribe --srt -o "$out" "$file"
		end
end
