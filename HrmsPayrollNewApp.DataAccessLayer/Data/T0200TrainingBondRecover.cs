using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0200TrainingBondRecover
{
    public decimal? TranId { get; set; }

    public decimal EmpId { get; set; }

    public decimal TrainingAprId { get; set; }

    public decimal RecoverAmount { get; set; }
}
