using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0040TsProjectMasterAhana
{
    public decimal ProjectId { get; set; }

    public string? ProjectName { get; set; }

    public string? ProjectCode { get; set; }

    public string? ProjectDescription { get; set; }

    public string? StartDate { get; set; }

    public string? DueDate { get; set; }

    public string? Duration { get; set; }

    public decimal? ProjectStatusId { get; set; }

    public string? TimeSheetApprovalType { get; set; }

    public int? Completed { get; set; }

    public int? Disabled { get; set; }

    public string? ClientName { get; set; }

    public decimal? CmpId { get; set; }
}
