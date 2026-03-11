import React, { useState } from "react";
import axios from "axios";
import DashboardLayout from "../layout/DashboardLayout";
import { useNavigate } from "react-router-dom";
import { KENYA_COUNTIES, SUB_COUNTIES } from "../data/kenyaLocations";
import {
  UserPlus,
  Calendar,
  Phone,
  Mail,
  MapPin,
  Shield,
  ChevronLeft,
  Loader,
  AlertCircle,
  CheckCircle,
  Hash
} from "lucide-react";

const InputField = ({ icon, name, label, value, onChange, type = "text", required = false, placeholder }) => (
  <div className="relative">
    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
      {icon}
    </div>
    <input
      type={type}
      name={name}
      value={value}
      onChange={onChange}
      className="w-full pl-10 p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-300"
      placeholder={placeholder || label}
      required={required}
    />
  </div>
);

const SelectField = ({ icon, name, label, value, onChange, options, required = false }) => (
  <div className="relative">
    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
      {icon}
    </div>
    <select
      name={name}
      value={value}
      onChange={onChange}
      className="w-full pl-10 p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-300"
      required={required}
    >
      {options.map((option) => (
        <option key={option.value} value={option.value}>
          {option.label}
        </option>
      ))}
    </select>
  </div>
);

const TextAreaField = ({ icon, name, label, value, onChange, placeholder, rows = 3 }) => (
  <div className="relative">
    <div className="absolute top-3 left-0 pl-3 flex items-center pointer-events-none">
      {icon}
    </div>
    <textarea
      name={name}
      value={value}
      onChange={onChange}
      rows={rows}
      className="w-full pl-10 p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-300"
      placeholder={placeholder || label}
    />
  </div>
);

const EMPTY_FORM = {
  first_name: "",
  last_name: "",
  national_id: "",
  gender: "",
  dob: "",
  // legacy age kept in case other parts of the app still read it
  age: "",
  age_years: "",
  age_months: "",
  age_days: "",
  phone: "",
  email: "",
  address: "",
  county: "Bungoma",
  sub_county: "Tongaren",
  ward: "",
  village: "",
  next_of_kin: "",
  next_of_kin_phone: "",
  pregnancy_status: "na",
  has_disability: false,
  disability_type: "",
};

const AddPatient = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({ ...EMPTY_FORM });

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  // ── Helpers ──────────────────────────────────────────────────────────────

  /**
   * Decompose a DOB string into exact { years, months, days } (all as strings).
   * This is the inverse of dobFromParts.
   */
  const decomposeAge = (dob) => {
    if (!dob) return { years: "", months: "", days: "" };
    const birth = new Date(dob);
    const today = new Date();
    if (isNaN(birth)) return { years: "", months: "", days: "" };

    let years  = today.getFullYear() - birth.getFullYear();
    let months = today.getMonth()    - birth.getMonth();
    let days   = today.getDate()     - birth.getDate();

    if (days < 0) {
      months -= 1;
      const prevMonth = new Date(today.getFullYear(), today.getMonth(), 0);
      days += prevMonth.getDate();
    }
    if (months < 0) {
      years  -= 1;
      months += 12;
    }

    return {
      years:  years  > 0 ? String(years)  : "",
      months: months > 0 ? String(months) : "",
      days:   days   > 0 ? String(days)   : "",
    };
  };

  /**
   * Compute an exact DOB by subtracting years, months, and days from today.
   * Returns "" if all parts are empty/zero.
   */
  const dobFromParts = (y, m, d) => {
    const years  = parseInt(y)  || 0;
    const months = parseInt(m)  || 0;
    const days   = parseInt(d)  || 0;
    if (!years && !months && !days) return "";
    const today = new Date();
    // Subtract years and months first, then days to handle month-boundary correctly
    const birth = new Date(
      today.getFullYear()  - years,
      today.getMonth()     - months,
      today.getDate()      - days
    );
    return birth.toISOString().split("T")[0];
  };

  // ── Handlers ─────────────────────────────────────────────────────────────

  /** Calendar changed → decompose the exact diff into years, months, days. */
  const handleDOBChange = (e) => {
    const dob = e.target.value;
    const { years, months, days } = decomposeAge(dob);
    setFormData((prev) => ({
      ...prev,
      dob,
      age:        years,
      age_years:  years,
      age_months: months,
      age_days:   days,
    }));
  };

  /** Years changed → recompute DOB using all three parts. */
  const handleYearsChange = (e) => {
    const raw = e.target.value;
    setFormData((prev) => {
      const dob = dobFromParts(raw, prev.age_months, prev.age_days);
      return { ...prev, age_years: raw, age: raw, dob };
    });
  };

  /** Months changed → recompute DOB using all three parts. */
  const handleMonthsChange = (e) => {
    const raw = e.target.value;
    setFormData((prev) => {
      const dob = dobFromParts(prev.age_years, raw, prev.age_days);
      return { ...prev, age_months: raw, dob };
    });
  };

  /** Days changed → recompute DOB using all three parts. */
  const handleDaysChange = (e) => {
    const raw = e.target.value;
    setFormData((prev) => {
      const dob = dobFromParts(prev.age_years, prev.age_months, raw);
      return { ...prev, age_days: raw, dob };
    });
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  // ── Submit ────────────────────────────────────────────────────────────────

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setSuccess("");
    setLoading(true);

    try {
      // Coerce age fields to integers before sending
      const payload = {
        ...formData,
        age_years:  parseInt(formData.age_years)  || 0,
        age_months: parseInt(formData.age_months) || 0,
        age_days:   parseInt(formData.age_days)   || 0,
      };
      await axios.post("/patients", payload, {
        headers: { "Content-Type": "application/json" },
      });

      setSuccess("Patient registered successfully!");
      setFormData({ ...EMPTY_FORM });

      setTimeout(() => {
        navigate("/patients");
      }, 1500);
    } catch (err) {
      console.error("Add patient error:", err.response?.data || err);
      if (err.response?.data?.errors) {
        const messages = Object.values(err.response.data.errors)
          .flat()
          .join(" ");
        setError(messages);
      } else {
        setError("Failed to register patient. Please check your input or backend connection.");
      }
    } finally {
      setLoading(false);
    }
  };

  // ── Render ────────────────────────────────────────────────────────────────

  return (
    <DashboardLayout>
      <div className="min-h-screen bg-gray-50">
        <div className="w-full">
          <div className="flex items-center mb-6">
            <button
              onClick={() => navigate(-1)}
              className="p-2 rounded-full hover:bg-gray-200 transition-colors duration-300 mr-4"
            >
              <ChevronLeft className="w-6 h-6 text-gray-600" />
            </button>
            <h1 className="text-3xl font-bold text-gray-800">Register New Patient</h1>
          </div>

          <div className="bg-white rounded-2xl shadow-xl overflow-hidden w-full">
            <div className="p-6 sm:p-8 bg-gradient-to-r from-blue-600 to-indigo-600">
              <div className="flex items-center">
                <UserPlus className="w-8 h-8 text-white mr-4" />
                <h2 className="text-2xl font-bold text-white">Patient Information</h2>
              </div>
            </div>

            <div className="p-6 sm:p-8">
              {error && (
                <div className="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded-lg flex items-center shadow-md">
                  <AlertCircle className="w-6 h-6 mr-3" />
                  <div>
                    <p className="font-bold">Error</p>
                    <p>{error}</p>
                  </div>
                </div>
              )}
              {success && (
                <div className="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-6 rounded-lg flex items-center shadow-md">
                  <CheckCircle className="w-6 h-6 mr-3" />
                  <div>
                    <p className="font-bold">Success</p>
                    <p>{success}</p>
                  </div>
                </div>
              )}

              <form onSubmit={handleSubmit} className="space-y-6">
                {/* Name */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <InputField
                    icon={<UserPlus className="w-5 h-5 text-gray-600" />}
                    name="first_name"
                    label="First Name"
                    value={formData.first_name}
                    onChange={handleChange}
                    required
                  />
                  <InputField
                    icon={<UserPlus className="w-5 h-5 text-gray-600" />}
                    name="last_name"
                    label="Last Name"
                    value={formData.last_name}
                    onChange={handleChange}
                    required
                  />
                </div>

                {/* Gender + ID */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <SelectField
                    icon={<UserPlus className="w-5 h-5 text-gray-600" />}
                    name="gender"
                    label="Select Gender"
                    value={formData.gender}
                    onChange={handleChange}
                    options={[
                      { value: "", label: "Select Gender" },
                      { value: "M", label: "Male" },
                      { value: "F", label: "Female" },
                      { value: "O", label: "Other" },
                    ]}
                    required
                  />
                  <InputField
                    icon={<Shield className="w-5 h-5 text-gray-600" />}
                    name="national_id"
                    label="National ID Number"
                    placeholder="ID Number"
                    value={formData.national_id}
                    onChange={handleChange}
                  />
                </div>

                {/* DOB + Age (Years / Months / Days) */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6 items-start">

                  {/* Date of birth calendar */}
                  <div>
                    <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1 flex items-center gap-1">
                      <Calendar className="w-3.5 h-3.5" /> Date of Birth
                    </label>
                    <input
                      type="date"
                      name="dob"
                      value={formData.dob}
                      onChange={handleDOBChange}
                      className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-300"
                    />
                  </div>

                  {/* Age — three separate integer boxes */}
                  <div>
                    <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wide mb-1 flex items-center gap-1">
                      <Hash className="w-3.5 h-3.5" /> Age
                      <span className="font-normal normal-case text-gray-400 ml-1">
                        (years syncs with DOB · months &amp; days are extra detail)
                      </span>
                    </label>
                    <div className="grid grid-cols-3 gap-2">
                      {/* Years */}
                      <div>
                        <input
                          type="number"
                          min="0"
                          max="150"
                          value={formData.age_years}
                          onChange={handleYearsChange}
                          className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-300 text-center"
                          placeholder="0"
                        />
                        <span className="block text-center text-xs text-gray-500 mt-0.5 font-medium">Years</span>
                      </div>
                      {/* Months */}
                      <div>
                        <input
                          type="number"
                          min="0"
                          max="11"
                          value={formData.age_months}
                          onChange={handleMonthsChange}
                          className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-300 text-center"
                          placeholder="0"
                        />
                        <span className="block text-center text-xs text-gray-500 mt-0.5 font-medium">Months</span>
                      </div>
                      {/* Days */}
                      <div>
                        <input
                          type="number"
                          min="0"
                          max="30"
                          value={formData.age_days}
                          onChange={handleDaysChange}
                          className="w-full p-3 bg-gray-50 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 transition-all duration-300 text-center"
                          placeholder="0"
                        />
                        <span className="block text-center text-xs text-gray-500 mt-0.5 font-medium">Days</span>
                      </div>
                    </div>
                  </div>
                </div>

                {/* Phone */}
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <InputField
                    icon={<Phone className="w-5 h-5 text-gray-600" />}
                    name="phone"
                    label="Phone Number"
                    value={formData.phone}
                    onChange={handleChange}
                  />
                </div>

                <InputField
                  icon={<Mail className="w-5 h-5 text-gray-600" />}
                  name="email"
                  label="Email Address"
                  type="email"
                  value={formData.email}
                  onChange={handleChange}
                />

                <TextAreaField
                  icon={<MapPin className="w-5 h-5 text-gray-600" />}
                  name="address"
                  label="Address"
                  value={formData.address}
                  onChange={handleChange}
                />

                {/* Geographic Information - OPTIONAL */}
                <div className="bg-gradient-to-r from-gray-50 to-gray-100 p-6 rounded-lg border border-gray-200">
                  <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                    <MapPin className="w-5 h-5 mr-2 text-indigo-600" />
                    Geographic Information
                    <span className="ml-2 text-sm font-normal text-gray-500">(Optional - Can add later)</span>
                  </h3>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div className="relative">
                      <label className="block text-sm font-medium text-gray-700 mb-1">County</label>
                      <select
                        name="county"
                        value={formData.county}
                        onChange={(e) => {
                          setFormData({ ...formData, county: e.target.value, sub_county: "" });
                        }}
                        className="w-full p-3 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                      >
                        <option value="">-- Select County --</option>
                        {KENYA_COUNTIES.map(county => (
                          <option key={county} value={county}>{county}</option>
                        ))}
                      </select>
                    </div>

                    <div className="relative">
                      <label className="block text-sm font-medium text-gray-700 mb-1">Sub-County</label>
                      <select
                        name="sub_county"
                        value={formData.sub_county}
                        onChange={handleChange}
                        className="w-full p-3 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                        disabled={!formData.county}
                      >
                        <option value="">-- Select Sub-County --</option>
                        {formData.county && SUB_COUNTIES[formData.county]?.map(sc => (
                          <option key={sc} value={sc}>{sc}</option>
                        ))}
                      </select>
                    </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
                    <InputField
                      icon={<MapPin className="w-5 h-5 text-gray-600" />}
                      name="ward"
                      label="Ward"
                      placeholder="Enter ward name"
                      value={formData.ward}
                      onChange={handleChange}
                    />
                    <InputField
                      icon={<MapPin className="w-5 h-5 text-gray-600" />}
                      name="village"
                      label="Village/Estate"
                      placeholder="Enter village or estate"
                      value={formData.village}
                      onChange={handleChange}
                    />
                  </div>
                </div>

                {/* Next of Kin - OPTIONAL */}
                <div className="bg-gradient-to-r from-blue-50 to-indigo-50 p-6 rounded-lg border border-indigo-200">
                  <h3 className="text-lg font-semibold text-gray-800 mb-4 flex items-center">
                    <UserPlus className="w-5 h-5 mr-2 text-indigo-600" />
                    Next of Kin
                    <span className="ml-2 text-sm font-normal text-gray-500">(Optional)</span>
                  </h3>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <InputField
                      icon={<UserPlus className="w-5 h-5 text-gray-600" />}
                      name="next_of_kin"
                      label="Next of Kin Name"
                      placeholder="Full name"
                      value={formData.next_of_kin}
                      onChange={handleChange}
                    />
                    <InputField
                      icon={<Phone className="w-5 h-5 text-gray-600" />}
                      name="next_of_kin_phone"
                      label="Next of Kin Phone"
                      placeholder="Phone number"
                      value={formData.next_of_kin_phone}
                      onChange={handleChange}
                    />
                  </div>
                </div>

                {/* Additional Information - OPTIONAL */}
                <div className="bg-gradient-to-r from-green-50 to-emerald-50 p-6 rounded-lg border border-green-200">
                  <h3 className="text-lg font-semibold text-gray-800 mb-4">Additional Information <span className="text-sm font-normal text-gray-500">(Optional)</span></h3>

                  {/* Pregnancy Status (if female) */}
                  {formData.gender === "F" && (
                    <div className="mb-4">
                      <label className="block text-sm font-medium text-gray-700 mb-1">Pregnancy Status</label>
                      <select
                        name="pregnancy_status"
                        value={formData.pregnancy_status}
                        onChange={handleChange}
                        className="w-full p-3 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                      >
                        <option value="na">Not Applicable</option>
                        <option value="yes">Pregnant</option>
                        <option value="no">Not Pregnant</option>
                        <option value="unknown">Unknown</option>
                      </select>
                    </div>
                  )}

                  {/* Disability */}
                  <div>
                    <label className="flex items-center mb-2">
                      <input
                        type="checkbox"
                        checked={formData.has_disability}
                        onChange={(e) => setFormData({
                          ...formData,
                          has_disability: e.target.checked,
                          disability_type: e.target.checked ? formData.disability_type : ""
                        })}
                        className="w-4 h-4 text-indigo-600 border-gray-300 rounded focus:ring-indigo-500 mr-2"
                      />
                      <span className="text-sm font-medium text-gray-700">Patient has a disability</span>
                    </label>
                  </div>

                  {formData.has_disability && (
                    <div className="mt-3">
                      <label className="block text-sm font-medium text-gray-700 mb-1">Disability Type</label>
                      <input
                        type="text"
                        name="disability_type"
                        value={formData.disability_type}
                        onChange={handleChange}
                        className="w-full p-3 bg-white border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500"
                        placeholder="e.g., Visual, Hearing, Physical, Mental"
                      />
                    </div>
                  )}
                </div>

                <div className="flex justify-end pt-4">
                  <button
                    type="submit"
                    disabled={loading}
                    className="w-full sm:w-auto flex items-center justify-center px-8 py-3 border border-transparent text-base font-medium rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 disabled:bg-indigo-400 disabled:cursor-not-allowed transition-all duration-300 shadow-lg hover:shadow-xl focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                  >
                    {loading ? (
                      <>
                        <Loader className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" />
                        Saving...
                      </>
                    ) : (
                      "Register Patient"
                    )}
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div >
    </DashboardLayout >
  );
};

export default AddPatient;
