using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0012CompanyCrtLoginMaster
{
    public decimal RowId { get; set; }

    public decimal? CmpId { get; set; }

    public DateTime? CreateDate { get; set; }

    public DateTime? LastLoginDate { get; set; }

    public virtual T0010CompanyMaster? Cmp { get; set; }
}
