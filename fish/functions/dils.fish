function dils
    set tab (printf "\t")
    begin
        printf "REPOSITORY\tTAG\tIMAGE_ID\tCREATED\tSIZE\n"
        docker image ls --format "{{.Repository}}$tab{{.Tag}}$tab{{.ID}}$tab{{.CreatedSince}}$tab{{.Size}}" \
                    | sort -k3,3 -k2,2 \
                    | awk -F '\t' '
            $2 != "latest" && !seen[$3]++ {
                preferred[$3] = $0
            }
            $2 == "latest" && !( $3 in preferred ) {
                fallback[$3] = $0
            }
            END {
                for (id in preferred) print preferred[id]
                for (id in fallback) if (!(id in preferred)) print fallback[id]
            }'
    end | column -s $tab -t
end
