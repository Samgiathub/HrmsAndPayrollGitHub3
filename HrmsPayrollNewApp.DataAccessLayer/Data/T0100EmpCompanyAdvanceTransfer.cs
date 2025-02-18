using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpCompanyAdvanceTransfer
{
    public decimal RowId { get; set; }

    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal OldBalance { get; set; }

    public decimal NewCmpId { get; set; }

    public decimal NewBalance { get; set; }

    public virtual T0095EmpCompanyTransfer Tran { get; set; } = null!;
}
