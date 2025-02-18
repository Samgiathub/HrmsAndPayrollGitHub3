using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0160HrmsTrainingQuestionnaireResponse
{
    public decimal TranResponseId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? TrainingAprId { get; set; }

    public decimal? TrainingId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? TranQuestionId { get; set; }

    public string? Answer { get; set; }

    public DateTime? CreateDate { get; set; }

    public decimal? MarksObtained { get; set; }

    public decimal? TranId { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual T0040HrmsTrainingMaster? Training { get; set; }

    public virtual T0120HrmsTrainingApproval? TrainingApr { get; set; }

    public virtual T0152HrmsTrainingQuestFinal? Tran { get; set; }

    public virtual T0150HrmsTrainingQuestionnaire? TranQuestion { get; set; }
}
