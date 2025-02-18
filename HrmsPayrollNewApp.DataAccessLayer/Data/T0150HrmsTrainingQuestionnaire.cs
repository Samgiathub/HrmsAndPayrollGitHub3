using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0150HrmsTrainingQuestionnaire
{
    public decimal TrainingQueId { get; set; }

    public string Question { get; set; } = null!;

    public string? TrainingId { get; set; }

    public decimal CmpId { get; set; }

    public int? QuestionniareType { get; set; }

    public string? QuestionType { get; set; }

    public int? SortingNo { get; set; }

    public string? QuestionOption { get; set; }

    public string? Answer { get; set; }

    public decimal? Marks { get; set; }

    public string? QuestionRowOption { get; set; }

    public int? QuestionRowType { get; set; }

    public string? VideoPath { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0150HrmsTrainingAnswer> T0150HrmsTrainingAnswers { get; set; } = new List<T0150HrmsTrainingAnswer>();

    public virtual ICollection<T0152HrmsTrainingQuestFinal> T0152HrmsTrainingQuestFinals { get; set; } = new List<T0152HrmsTrainingQuestFinal>();

    public virtual ICollection<T0160HrmsManagerFeedbackResponse> T0160HrmsManagerFeedbackResponses { get; set; } = new List<T0160HrmsManagerFeedbackResponse>();

    public virtual ICollection<T0160HrmsTrainingQuestionnaireResponse> T0160HrmsTrainingQuestionnaireResponses { get; set; } = new List<T0160HrmsTrainingQuestionnaireResponse>();
}
