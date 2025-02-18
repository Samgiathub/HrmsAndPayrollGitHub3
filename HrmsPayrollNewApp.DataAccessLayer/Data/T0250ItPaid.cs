using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0250ItPaid
{
    public decimal ItPaidId { get; set; }

    public decimal CmpId { get; set; }

    public DateTime ForDate { get; set; }

    public string ItTranYear { get; set; } = null!;

    public DateTime ItPaymentDate { get; set; }

    public string ItChallanNo { get; set; } = null!;

    public string ItAcknowledgementNo { get; set; } = null!;

    public string ItBankName { get; set; } = null!;

    public string ItBankBsrCode { get; set; } = null!;

    public string ItPaymentMode { get; set; } = null!;

    public string ItChequeNo { get; set; } = null!;

    public decimal ItAmount { get; set; }

    public decimal ItInterestAmount { get; set; }

    public decimal ItOtherAmount { get; set; }

    public decimal ItTotalAmount { get; set; }

    public string ItComments { get; set; } = null!;

    public decimal LoginId { get; set; }

    public DateTime SystemDate { get; set; }

    public virtual T0010CompanyMaster Cmp { get; set; } = null!;

    public virtual ICollection<T0251ItPaidDetail> T0251ItPaidDetails { get; set; } = new List<T0251ItPaidDetail>();
}
