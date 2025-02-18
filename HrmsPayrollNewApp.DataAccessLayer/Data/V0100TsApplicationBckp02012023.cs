using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0100TsApplicationBckp02012023
{
    public decimal TimesheetId { get; set; }

    public decimal? EmployeeId { get; set; }

    public string? TimesheetPeriod { get; set; }

    public string? TimesheetType { get; set; }

    public string? EntryDate { get; set; }

    public string? TotalTime { get; set; }

    public decimal ProjectStatusId { get; set; }

    public decimal? ProjectId { get; set; }

    public decimal? TaskId { get; set; }

    public string EmpName { get; set; } = null!;

    public decimal? CmpId { get; set; }

    public string ProjectStatus { get; set; } = null!;

    public string? Description { get; set; }

    public decimal? EmpSuperior { get; set; }

    public string? AlphaEmpCode { get; set; }

    public string? EmpFullName { get; set; }

    public string Tscolor { get; set; } = null!;

    public string? Attachment { get; set; }

    public decimal BranchId { get; set; }

    public string? ProjectCode { get; set; }

    public decimal? ClientId { get; set; }
}
