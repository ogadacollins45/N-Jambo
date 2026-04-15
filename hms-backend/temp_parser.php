<?php

$data = json_decode(file_get_contents("e:/G/Code/NaitiriJamboHMS/NJ2/Nj2/N-Jambo/lab.json"), true);
$result = [];

function generateRowBuilder($row, $columns) {
    $code = $row['code'];
    $label = addslashes($row['label']);
    
    $colsArray = array_column($columns, 'name');
    
    if (in_array('culture_positive', $colsArray)) {
        return "['code' => '$code', 'label' => '$label', 'total_exam' => 0, 'total_cultures' => 0, 'culture_positive' => 0]";
    }
    if (in_array('number_contaminated', $colsArray)) {
        return "['code' => '$code', 'label' => '$label', 'total_exam' => 0, 'number_positive' => 0, 'number_contaminated' => 0]";
    }
    if (in_array('malignant', $colsArray)) {
        return "['code' => '$code', 'label' => '$label', 'total_exam' => 0, 'malignant' => 0]";
    }
    if (in_array('total_exam', $colsArray) && in_array('number_positive', $colsArray)) {
        return "\$r('$code', '$label')";
    }
    if (in_array('total_exam', $colsArray)) { // just total_exam? wait TB has number_positive.
        if (!in_array('number_positive', $colsArray)) {
             return "['code' => '$code', 'label' => '$label', 'total_exam' => 0]"; // Wait, cytology has malignant, covered above
        }
    }
    if (in_array('number_positive', $colsArray)) {
        return "\$rnp('$code', '$label')";
    }
    // minimal
    return "['code' => '$code', 'label' => '$label']";
}

foreach ($data as $section) {
    if (in_array($section['section_number'], ['5', '6'])) {
        $num = $section['section_number'];
        $title = $section['section_title'];
        
        echo "            '$num' => [\n";
        echo "                'number' => '$num',\n";
        echo "                'title'  => '$title',\n";
        echo "                'subsections' => [\n";
        
        foreach ($section['subsections'] as $sub) {
            $subCode = $sub['subsection_code'];
            $subTitle = addslashes($sub['subsection_title']);
            $cols = [];
            foreach ($sub['columns'] as $c) {
                if ($c['name'] !== 'test_code' && $c['name'] !== 'sample_name' && $c['name'] !== 'test_name' && $c['name'] !== 'organism' && $c['name'] !== 'sample_type') {
                    $cols[] = "'" . $c['name'] . "'";
                }
            }
            $colsStr = implode(", ", $cols);
            
            echo "                    [\n";
            echo "                        'title'   => '$subTitle',\n";
            echo "                        'code'    => '$subCode',\n";
            echo "                        'columns' => [$colsStr],\n";
            echo "                        'rows'    => [\n";
            
            foreach ($sub['rows'] as $r) {
                if (isset($r['row_type']) && $r['row_type'] === 'summary') {
                    // Summary row usually has total_exam + number_positive
                    echo "                            \$r('{$r['code']}', '" . addslashes($r['label']) . "'),\n";
                } elseif (isset($r['row_type']) && $r['row_type'] === 'organism') {
                    // Organism row only has number_positive
                    echo "                            \$rnp('{$r['code']}', '" . addslashes($r['label']) . "'),\n";
                } else {
                    echo "                            " . generateRowBuilder($r, $sub['columns']) . ",\n";
                }
            }
            echo "                        ]\n                    ],\n";
        }
        echo "                ]\n            ],\n";
    }
}
