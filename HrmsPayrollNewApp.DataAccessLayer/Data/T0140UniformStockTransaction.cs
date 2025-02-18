using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0140UniformStockTransaction
{
    public decimal StockId { get; set; }

    public decimal CmpId { get; set; }

    public decimal UniId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal StockOpening { get; set; }

    public decimal StockCredit { get; set; }

    public decimal StockDebit { get; set; }

    public decimal StockBalance { get; set; }

    public decimal StockPosting { get; set; }

    public string? ModifyBy { get; set; }

    public DateTime? ModifyDate { get; set; }

    public string? IpAddress { get; set; }

    public decimal? FabricPrice { get; set; }
}
