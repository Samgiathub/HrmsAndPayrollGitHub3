using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0160OtApprove
{
    public string? EmpFullName { get; set; }

    public decimal TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal WorkingSec { get; set; }

    public decimal OtSec { get; set; }

    public byte IsApproved { get; set; }

    public decimal ApprovedOtSec { get; set; }

    public string Comments { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public string EmpFirstName { get; set; } = null!;

    public decimal BranchId { get; set; }

    public decimal EmpCode { get; set; }

    public string? ApprovedOtHours { get; set; }

    public decimal? EmpSuperior { get; set; }

    public decimal? PDaysCount { get; set; }

    public byte IsMonthWise { get; set; }

    public decimal WeekoffOtSec { get; set; }

    public decimal ApprovedWoOtSec { get; set; }

    public string ApprovedWoOtHours { get; set; } = null!;

    public decimal HolidayOtSec { get; set; }

    public decimal ApprovedHoOtSec { get; set; }

    public string ApprovedHoOtHours { get; set; } = null!;

    public string? AlphaEmpCode { get; set; }

    public string? Remark { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public string? BranchName { get; set; }

    public string? DeptName { get; set; }

    public string DesigName { get; set; } = null!;

    public string GrdName { get; set; } = null!;

    public string? TypeName { get; set; }

    public string? VerticalName { get; set; }

    public string? SubVerticalName { get; set; }

    public string SegmentName { get; set; } = null!;
}
