using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0150HrmsTrainingQuestionnaire
{
    public decimal TrainingQueId { get; set; }

    public string Question { get; set; } = null!;

    public string? TrainingId { get; set; }

    public decimal CmpId { get; set; }

    public int QuestionniareType { get; set; }

    public string? QuestionniareType1 { get; set; }

    public string QuestionType { get; set; } = null!;

    public string QuestionType1 { get; set; } = null!;

    public int SortingNo { get; set; }

    public string? QuestionOption { get; set; }

    public string? Answer { get; set; }

    public decimal? Marks { get; set; }

    public string? TrainingName { get; set; }

    public string? QuestionRowOption { get; set; }

    public int? QuestionRowType { get; set; }

    public string? VideoPath { get; set; }
}
