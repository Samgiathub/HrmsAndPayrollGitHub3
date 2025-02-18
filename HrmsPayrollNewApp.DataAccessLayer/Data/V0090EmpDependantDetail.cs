using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0090EmpDependantDetail
{
    public string? EmpCode { get; set; }

    public string? EmployeeName { get; set; }

    public string? BranchName { get; set; }

    public string Grade { get; set; } = null!;

    public string Designation { get; set; } = null!;

    public string? DateOfJoin { get; set; }

    public decimal? BasicSalary { get; set; }

    public decimal? GrossSalary { get; set; }

    public string? FatherName { get; set; }

    public string? DateOfBirth { get; set; }

    public string? MarritalStatus { get; set; }

    public string NameOfNominee { get; set; } = null!;

    public string Relation { get; set; } = null!;

    public string? NomineeAddress { get; set; }

    public decimal? NomineeAge { get; set; }

    public string? IsResidentWithNominee { get; set; }

    public decimal? NomineeShare { get; set; }

    public string? NomineeFor { get; set; }

    public decimal BranchId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }
}
