using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0160HrmsTrainingQuestionnaireResponseInduction
{
    public decimal TranResponseId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal ChecklistId { get; set; }

    public decimal? TrainingId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? TranQuestionId { get; set; }

    public string? Answer { get; set; }

    public DateTime? CreateDate { get; set; }

    public decimal? MarksObtained { get; set; }

    public decimal? ChecklistFunId { get; set; }

    public byte InductionTrainingType { get; set; }

    public byte? TrainingAttemptCount { get; set; }
}
