using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpCompanyBondTransfer
{
    public decimal RowId { get; set; }

    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal BondId { get; set; }

    public decimal OldBalance { get; set; }

    public decimal NewCmpId { get; set; }

    public decimal NewEmpId { get; set; }

    public decimal NewBondId { get; set; }

    public decimal NewBalance { get; set; }

    public decimal BondRowId { get; set; }

    public decimal? NewBondAprId { get; set; }

    public virtual T0095EmpCompanyTransfer Tran { get; set; } = null!;
}
