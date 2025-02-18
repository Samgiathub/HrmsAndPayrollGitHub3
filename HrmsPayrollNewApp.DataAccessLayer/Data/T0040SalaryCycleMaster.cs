using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0040SalaryCycleMaster
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public string Name { get; set; } = null!;

    public DateTime SalaryStDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;
}
