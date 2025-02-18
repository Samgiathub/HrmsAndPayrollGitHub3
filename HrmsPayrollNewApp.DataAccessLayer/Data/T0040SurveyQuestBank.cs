using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SurveyQuestBank
{
    public decimal SurveyQuestBankId { get; set; }

    public decimal? CmpId { get; set; }

    public string? SurveyQuestion { get; set; }

    public string? SurveyType { get; set; }

    public string? QuestionOption { get; set; }

    public string? Answer { get; set; }

    public double? Marks { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }
}
