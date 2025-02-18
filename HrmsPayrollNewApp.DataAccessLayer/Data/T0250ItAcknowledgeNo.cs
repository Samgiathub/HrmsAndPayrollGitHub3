using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0250ItAcknowledgeNo
{
    public decimal RowId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoginId { get; set; }

    public decimal? TransactionId { get; set; }

    public string? FinancialYear { get; set; }

    public string? FirstQaurterNo { get; set; }

    public string? SecondQaurterNo { get; set; }

    public string? ThirdQaurterNo { get; set; }

    public string? FourthQaurterNo { get; set; }

    public DateTime? Sysdate { get; set; }

    public decimal? FirstQaurterAmount { get; set; }

    public decimal? SecondQaurterAmount { get; set; }

    public decimal? ThirdQaurterAmount { get; set; }

    public decimal? FourthQaurterAmount { get; set; }
}
