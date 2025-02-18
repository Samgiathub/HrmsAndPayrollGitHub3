using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class PovDetailsTrident
{
    public decimal EId { get; set; }

    public decimal CmpId { get; set; }

    public string CompCd { get; set; } = null!;

    public string CompCdDesc { get; set; } = null!;

    public decimal Empid { get; set; }

    public string? EmpCd { get; set; }

    public string? Prefix { get; set; }

    public string? EmpNm { get; set; }

    public string Fname { get; set; } = null!;

    public string Mname { get; set; } = null!;

    public string Lname { get; set; } = null!;

    public DateTime DtJoin { get; set; }

    public DateTime? DtBirth { get; set; }

    public string? MarSt { get; set; }

    public string Sex { get; set; } = null!;

    public string? DesigCdDesc { get; set; }

    public string? BusinessUnit { get; set; }

    public string? Section { get; set; }

    public string? Location { get; set; }

    public string? NewDivision { get; set; }

    public DateTime? IncrDt { get; set; }

    public string? Grade { get; set; }

    public decimal? BasicSalary { get; set; }

    public decimal? Gross { get; set; }

    public decimal? Ctc { get; set; }

    public string? SsnNo { get; set; }

    public string? SinNo { get; set; }

    public string? DrLicNo { get; set; }

    public string? PanNo { get; set; }

    public string? Email { get; set; }

    public string? Bldgrp { get; set; }

    public string? AadhaarNo { get; set; }

    public string? EName { get; set; }

    public string? EmergencyContact { get; set; }

    public string? MName { get; set; }

    public string? FathNm { get; set; }

    public string? FathNm1 { get; set; }

    public string? ContractorName { get; set; }

    public string? ContractorAddress { get; set; }

    public string? SubContractor { get; set; }

    public string? VendorCode { get; set; }

    public string? ContractorCity { get; set; }

    public string? ContractorState { get; set; }

    public string? ContractorCompanyName { get; set; }

    public string? SubDepartment { get; set; }

    public string? EmployeeType { get; set; }

    public string? CostCenter { get; set; }

    public string? Division { get; set; }

    public string? MainDepartment { get; set; }

    public DateTime LatestIncrementDate { get; set; }

    public DateTime? LeftDate { get; set; }

    public DateTime? ResignDate { get; set; }

    public string? LeftReason { get; set; }

    public string? PfNo { get; set; }

    public string? EsicNo { get; set; }

    public string? PmntStreet { get; set; }

    public string? PmntCity { get; set; }

    public string? PmntDistrict { get; set; }

    public string? PmntState { get; set; }

    public string? PmntPincode { get; set; }

    public string? PmntThanaName { get; set; }

    public string? Homeno { get; set; }

    public string? Currentcell { get; set; }

    public string? WorkTelNo { get; set; }

    public string? OtherEmail { get; set; }

    public string? PrsntStreet { get; set; }

    public string? PrsntCity { get; set; }

    public string? PrsntDistrict { get; set; }

    public string? PrsntState { get; set; }

    public string? PrsntPincode { get; set; }

    public string? PrsntThanaName { get; set; }

    public string EmployeeStaus { get; set; } = null!;

    public string? NewBusinessUnit { get; set; }
}
