using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0110DependentDetail
{
    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal BranchId { get; set; }

    public string? BranchName { get; set; }

    public string Grade { get; set; } = null!;

    public string Designation { get; set; } = null!;

    public decimal? BasicSalary { get; set; }

    public decimal? GrossSalary { get; set; }

    public string? EmpName { get; set; }

    public string? DateOfJoin { get; set; }

    public string DependentName { get; set; } = null!;

    public string Gender { get; set; } = null!;

    public string? FatherName { get; set; }

    public string? DateOfBirth { get; set; }

    public decimal? DependentAge { get; set; }

    public string? Relationship { get; set; }

    public string? IsDependant { get; set; }

    public string? MarritalStatus { get; set; }

    public string Height { get; set; } = null!;

    public string Weight { get; set; } = null!;

    public string Occupation { get; set; } = null!;

    public string Hobby { get; set; } = null!;

    public string DependentCompanyName { get; set; } = null!;

    public string DependentCompanyCity { get; set; } = null!;

    public string DependentWorkTime { get; set; } = null!;

    public string DependentStandard { get; set; } = null!;

    public string StandardSpecialization { get; set; } = null!;

    public string DependentShcoolCollege { get; set; } = null!;

    public string DependentShcoolCollegeCity { get; set; } = null!;

    public string DependentExtraActivity { get; set; } = null!;
}
