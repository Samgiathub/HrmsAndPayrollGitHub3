using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0100EmpCompanyTransferEarnDeduction
{
    public decimal RowId { get; set; }

    public decimal TranId { get; set; }

    public decimal OldCmpId { get; set; }

    public decimal OldEmpId { get; set; }

    public decimal? OldAdId { get; set; }

    public string? OldMode { get; set; }

    public decimal? OldPercentage { get; set; }

    public decimal? OldAmount { get; set; }

    public decimal NewCmpId { get; set; }

    public decimal NewEmpId { get; set; }

    public decimal? NewAdId { get; set; }

    public string? NewMode { get; set; }

    public decimal? NewPercentage { get; set; }

    public decimal? NewAmount { get; set; }

    public decimal AdRowId { get; set; }

    public virtual T0095EmpCompanyTransfer Tran { get; set; } = null!;
}
