using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100EmployeeIcardDetail
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime EffectiveDate { get; set; }

    public DateTime? ExpiryDate { get; set; }

    public string? Comments { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpSecondName { get; set; }

    public string? EmpLastName { get; set; }

    public decimal EmpId { get; set; }

    public decimal? EmpCode { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal BranchId { get; set; }

    public bool IsRecovered { get; set; }

    public string? Reason { get; set; }

    public decimal GrdId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SegmentId { get; set; }

    public string IsRecovered1 { get; set; } = null!;

    public DateTime? ReturnDate { get; set; }

    public int LeftEmp { get; set; }

    public DateTime IssueDate { get; set; }

    public decimal? CatId { get; set; }

    public decimal? SubBranchId { get; set; }

    public string? BloodGroup { get; set; }

    public string? FatherName { get; set; }

    public DateTime? DateOfBirth { get; set; }

    public string? EmpCategory { get; set; }

    public int? SkillTypeId { get; set; }

    public decimal IssueBy { get; set; }
}
