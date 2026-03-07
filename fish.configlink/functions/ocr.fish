function ocr
		if test (count $argv) -eq 0
				echo "Usage: ocr <file1> [file2 ...]"
				return 1
		end

		for file in $argv
				if not test -f "$file"
						echo "File not found: $file"
						continue
				end

				if not string match -qi "*.pdf" "$file"
						echo "Not a PDF file: $file"
						continue
				end

				set base (string replace -r '\.pdf$' '' "$file")
				set out "$base"_ocr.pdf

				echo "Processing $file → $out"
				ocrmypdf -d -c "$file" "$out"
		end
end
