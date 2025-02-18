using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0052SurveyTemplate
{
    public decimal SurveyQuestionId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SurveyId { get; set; }

    public string? SurveyQuestion { get; set; }

    public string? SurveyType { get; set; }

    public int? SortingNo { get; set; }

    public string? QuestionOption { get; set; }

    public byte SubQuestion { get; set; }

    public byte IsMandatory { get; set; }

    public string? Answer { get; set; }

    public double? Marks { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0050SurveyMaster? Survey { get; set; }

    public virtual ICollection<T0060SurveyEmployeeResponse> T0060SurveyEmployeeResponses { get; set; } = new List<T0060SurveyEmployeeResponse>();
}
