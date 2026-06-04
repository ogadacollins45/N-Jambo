import React, { useState, useEffect, useRef } from "react";
import axios from "axios";
import { Search, Loader } from "lucide-react";
import diseasesList from "../data/diseases_dropdown.json";

const API_BASE_URL = `${import.meta.env.VITE_API_BASE_URL}/api`;

const SearchableDiagnosisDropdown = ({ value, onChange, placeholder = "Search for a diagnosis..." }) => {
  const [options, setOptions] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [baseValue, setBaseValue] = useState("");
  const [clarification, setClarification] = useState("");
  const [isOpen, setIsOpen] = useState(false);
  const [loading, setLoading] = useState(true);
  const dropdownRef = useRef(null);

  useEffect(() => {
    // Fetch custom diagnoses
    const fetchCustomDiagnoses = async () => {
      try {
        const token = localStorage.getItem("token");
        const res = await axios.get(`${API_BASE_URL}/system-diagnoses`, {
          headers: { Authorization: `Bearer ${token}` }
        });

        const customDiagnoses = res.data.map(d => ({
          label: d.name,
          value: d.name,
          isCustom: true
        }));

        // Combine custom and predefined
        const allDiagnoses = [...customDiagnoses, ...diseasesList];

        // Ensure "All Other Diseases" is in the list
        const hasOther = allDiagnoses.some(d => d.value === "All Other Diseases");
        if (!hasOther) {
          allDiagnoses.push({ label: "All Other Diseases", value: "All Other Diseases" });
        }

        // Remove duplicates by value
        const unique = [];
        const seen = new Set();
        for (const item of allDiagnoses) {
          if (!seen.has(item.value.toLowerCase())) {
            seen.add(item.value.toLowerCase());
            unique.push(item);
          }
        }

        // Sort alphabetically
        unique.sort((a, b) => a.label.localeCompare(b.label));

        setOptions(unique);
      } catch (err) {
        console.error("Failed to load custom diagnoses", err);
        // Fallback to just predefined
        setOptions(diseasesList);
      } finally {
        setLoading(false);
      }
    };

    fetchCustomDiagnoses();
  }, []);

  // Set initial search term if value is provided
  useEffect(() => {
    if (value && !isOpen) {
      if (value.startsWith("All Other Diseases - ")) {
        setBaseValue("All Other Diseases");
        setSearchTerm("All Other Diseases");
        setClarification(value.substring("All Other Diseases - ".length));
      } else if (value === "All Other Diseases") {
        setBaseValue("All Other Diseases");
        setSearchTerm("All Other Diseases");
        setClarification("");
      } else {
        setBaseValue(value);
        setSearchTerm(value);
        setClarification("");
      }
    } else if (!value && !isOpen) {
      setBaseValue("");
      setSearchTerm("");
      setClarification("");
    }
  }, [value, isOpen]);

  // Click outside listener
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsOpen(false);
        // Reset search term to selected value when closing without selection
        if (baseValue) {
          setSearchTerm(baseValue);
        } else {
          setSearchTerm("");
        }
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [baseValue]);

  const filteredOptions = options.filter(option =>
    option.label.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const handleSelection = (selectedValue) => {
    setSearchTerm(selectedValue);
    setBaseValue(selectedValue);
    setIsOpen(false);

    if (selectedValue === "All Other Diseases") {
      onChange(`All Other Diseases${clarification ? ' - ' + clarification : ''}`);
    } else {
      setClarification("");
      onChange(selectedValue);
    }
  };

  const handleClarificationChange = (text) => {
    setClarification(text);
    onChange(`All Other Diseases - ${text}`);
  };

  return (
    <div className="relative" ref={dropdownRef}>
      <div className="relative">
        <input
          type="text"
          className="w-full p-3 pl-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-transparent"
          placeholder={loading ? "Loading diagnoses..." : placeholder}
          value={searchTerm}
          onChange={(e) => {
            setSearchTerm(e.target.value);
            setIsOpen(true);
            // Allow manual entry by emitting value as they type?
            // Actually user wanted defined list instead of manual diagnosis.
            // But we can let them clear it.
            if (e.target.value === "") {
              onChange("");
              setBaseValue("");
              setClarification("");
            }
          }}
          onFocus={() => setIsOpen(true)}
          disabled={loading}
        />
        <div className="absolute left-3 top-3.5 text-gray-400">
          {loading ? <Loader size={18} className="animate-spin" /> : <Search size={18} />}
        </div>
      </div>

      {isOpen && !loading && (
        <div className="absolute z-10 w-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg max-h-60 overflow-y-auto">
          {filteredOptions.length > 0 ? (
            filteredOptions.map((option, idx) => (
              <div
                key={idx}
                className="px-4 py-2 hover:bg-indigo-50 cursor-pointer text-sm text-gray-700"
                onClick={() => handleSelection(option.value)}
              >
                {option.label}
                {option.isCustom && <span className="ml-2 text-xs text-indigo-500 font-semibold">(Custom)</span>}
              </div>
            ))
          ) : (
            <div className="px-4 py-3 text-sm text-gray-500 italic text-center">
              No matching diagnosis found.
            </div>
          )}
        </div>
      )}

      {baseValue === "All Other Diseases" && (
        <div className="mt-3 p-3 bg-indigo-50 rounded-lg border border-indigo-100">
          <label className="block text-xs font-semibold text-indigo-700 mb-1">

            Enter impression manually...
          </label>
          <input
            type="text"
            className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-indigo-500 focus:border-transparent text-sm"
            placeholder="Type custom impression here..."
            value={clarification}
            onChange={(e) => handleClarificationChange(e.target.value)}
            required
          />
        </div>
      )}
    </div>
  );
};

export default SearchableDiagnosisDropdown;
