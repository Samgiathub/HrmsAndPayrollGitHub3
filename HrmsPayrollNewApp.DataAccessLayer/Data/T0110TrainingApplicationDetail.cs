using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0110TrainingApplicationDetail
{
    public decimal TranAppDetailId { get; set; }

    public decimal? TrainingAppId { get; set; }

    public decimal EmpId { get; set; }

    public virtual T0080EmpMaster Emp { get; set; } = null!;

    public virtual T0100TrainingApplication? TrainingApp { get; set; }
}
