using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100WeekoffAdj
{
    public decimal WTranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string WeekoffDay { get; set; } = null!;

    public string EmpFirstName { get; set; } = null!;

    public string EmpLastName { get; set; } = null!;

    public string? GrdName { get; set; }

    public string? EmpFullName { get; set; }

    public string? EmpLeft { get; set; }

    public decimal BranchId { get; set; }

    public decimal EmpCode { get; set; }

    public string? WeekoffDayValue { get; set; }

    public string? BranchName { get; set; }

    public string? BranchCode { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? AlphaEmpCode { get; set; }

    public decimal? VerticalId { get; set; }

    public decimal? SubVerticalId { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? TypeId { get; set; }

    public decimal GrdId { get; set; }

    public decimal? CatId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? SubBranchId { get; set; }

    public decimal? SegmentId { get; set; }

    public string? AltWName { get; set; }

    public string? AltWFullDayCont { get; set; }

    public string? AltWNameDayCount { get; set; }

    public string? WeekOffOddEven { get; set; }
}
