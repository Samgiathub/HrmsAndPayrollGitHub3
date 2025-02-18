using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0130HrmsTrainingEmployeeDetail
{
    public decimal TranEmpDetailId { get; set; }

    public decimal? TrainingAppId { get; set; }

    public decimal? TrainingAprId { get; set; }

    public decimal? EmpId { get; set; }

    public int? EmpTranStatus { get; set; }

    public decimal CmpId { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual T0080EmpMaster? Emp { get; set; }

    public virtual ICollection<T0140HrmsTrainingFeedback> T0140HrmsTrainingFeedbacks { get; set; } = new List<T0140HrmsTrainingFeedback>();

    public virtual T0100HrmsTrainingApplication? TrainingApp { get; set; }

    public virtual T0120HrmsTrainingApproval? TrainingApr { get; set; }
}
