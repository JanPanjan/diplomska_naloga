import json
import csv
import glob

report = []

# parsaj json datoteke
for f in glob.glob("sword_output/*/*.json"):
    with open(f, "r") as fp:
        obj = json.load(fp)
        aidx = obj["Ambiguity index"]

        # ime proteina
        pname = f.removeprefix("sword_output/").removesuffix("/SWORD2_summary.json")[:8]

        # ocena optimalne particije
        q = obj["Optimal partition"]["Quality"]

        # najvišja ocena dekompozicije
        maxq = q
        for key in obj:
            if key.find("partition") != -1:
                tmpq = obj[key]["Quality"]
                if tmpq > maxq:
                    maxq = tmpq

    report.append({
        "Protein": pname,
        "AmbiguityIndex": len(aidx),
        "OptimalQuality": len(q),
        "MaxQuality": len(maxq)
    })

# zapiši report v datoteko
with open("decomposition_qualities.csv", "w", newline='') as csvfile:
    writer = csv.DictWriter(csvfile, fieldnames=report[0].keys())
    writer.writeheader()

    for row in report:
        writer.writerow(row)

# glej decompositions.r ...