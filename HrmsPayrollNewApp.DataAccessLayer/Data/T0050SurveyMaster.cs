using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0050SurveyMaster
{
    public decimal SurveyId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime? SurveyStartDate { get; set; }

    public DateTime? SurveyEndDate { get; set; }

    public string? SurveyTitle { get; set; }

    public string? SurveyPurpose { get; set; }

    public string? SurveyInstruction { get; set; }

    public DateTime? SurveyOpenTill { get; set; }

    public decimal? SurveyCreatedBy { get; set; }

    public decimal? BranchId { get; set; }

    public string? SurveyEmpId { get; set; }

    public DateTime? SurveyUpdateDate { get; set; }

    public string? DesigId { get; set; }

    public string StartTime { get; set; } = null!;

    public string EndTime { get; set; } = null!;

    public int MinPassingCriteria { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0052SurveyTemplate> T0052SurveyTemplates { get; set; } = new List<T0052SurveyTemplate>();

    public virtual ICollection<T0060SurveyEmployeeResponse> T0060SurveyEmployeeResponses { get; set; } = new List<T0060SurveyEmployeeResponse>();
}
