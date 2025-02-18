using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100TsProjectDetailsTimesheetSummary
{
    public string? FromDate { get; set; }

    public string? Todate { get; set; }

    public string? TimesheetPeriod { get; set; }

    public decimal? Monday { get; set; }

    public decimal? Tuesday { get; set; }

    public decimal? Wednesday { get; set; }

    public decimal? Thursday { get; set; }

    public decimal? Friday { get; set; }

    public decimal? Saturday { get; set; }

    public decimal? Sunday { get; set; }

    public decimal? TotalSecond { get; set; }

    public string? EmpName { get; set; }

    public decimal? EmpSuperior { get; set; }

    public decimal? DeptId { get; set; }

    public decimal? DesigId { get; set; }

    public decimal? ProjectStatusId { get; set; }

    public decimal? ProjectId { get; set; }

    public decimal? TaskId { get; set; }

    public decimal? CmpId { get; set; }

    public string? ProjectStatus { get; set; }

    public decimal? EmployeeId { get; set; }

    public decimal TimesheetId { get; set; }

    public string? ProjectName { get; set; }

    public string? TimesheetType { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string? TaskName { get; set; }

    public string? TaskCode { get; set; }

    public decimal? TimesheetDetailId { get; set; }
}
