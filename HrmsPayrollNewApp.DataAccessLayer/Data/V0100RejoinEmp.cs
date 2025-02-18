using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100RejoinEmp
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime LeftDate { get; set; }

    public string Remarks { get; set; } = null!;

    public DateTime RejoinDate { get; set; }

    public decimal? EmpCode { get; set; }

    public string? EmpFirstName { get; set; }

    public DateTime SystemDate { get; set; }

    public DateTime? DateOfJoin { get; set; }

    public string? Gender { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? GrdId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public string? GrdName { get; set; }

    public string? DeptName { get; set; }

    public string? BranchName { get; set; }

    public string? DesigName { get; set; }

    public string? AlphaEmpCode { get; set; }
}
