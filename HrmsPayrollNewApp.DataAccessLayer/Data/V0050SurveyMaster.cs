using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0050SurveyMaster
{
    public decimal SurveyId { get; set; }

    public decimal CmpId { get; set; }

    public string? SurveyStartDate { get; set; }

    public DateTime? SurveyEndDate { get; set; }

    public int MinPassingCriteria { get; set; }

    public string? SurveyEndDate1 { get; set; }

    public string? SurveyStartDate1 { get; set; }

    public string? SurveyTitle { get; set; }

    public string? SurveyPurpose { get; set; }

    public string? SurveyOpenTill { get; set; }

    public string? SurveyInstruction { get; set; }

    public decimal? SurveyCreatedBy { get; set; }

    public decimal? BranchId { get; set; }

    public string? DesigId { get; set; }

    public string? BranchName { get; set; }

    public string? DesigName { get; set; }

    public string? SurveyEmpId { get; set; }

    public string? Employee { get; set; }

    public string StartTime { get; set; } = null!;

    public string EndTime { get; set; } = null!;
}
