using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0152HrmsTrainingQuestFinal
{
    public decimal? TranId { get; set; }

    public decimal? Marks { get; set; }

    public string Question { get; set; } = null!;

    public int QuestionniareType { get; set; }

    public string QuestionType { get; set; } = null!;

    public int SortingNo { get; set; }

    public string? Answer { get; set; }

    public string? QuestionOption { get; set; }

    public string? TrainingName { get; set; }

    public string? TrainingId { get; set; }

    public string QuestionType1 { get; set; } = null!;

    public decimal CmpId { get; set; }

    public decimal TrainingQueId { get; set; }

    public decimal? TrainingAprId { get; set; }
}
