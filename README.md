# Bunu duyuyor musun?

İşitme yeteneğini test etmenin ve geliştirmenin eğlenceli bir yolu.

**▶ [sinancanan.github.io/bunu-duyuyor-musun](https://sinancanan.github.io/bunu-duyuyor-musun/)**
— kulaklıkla aç.

Tarayıcıda çalışan tek dosyalık bir uygulama. Kurulum, derleme adımı, paket
yöneticisi ve ses dosyası **yok** — flüt tınısı dahil bütün sesler Web Audio
API ile anlık üretilir. Giriş yapmadan oynadığın sürece hiçbir veri sunucuya
gitmez; her şey `localStorage`'da kalır.

Girişin **tamamen opsiyonel**: hesap açarsan ilerlemen [Supabase](https://supabase.com)
üzerinden cihazlar arası senkronize olur (bkz. [Hesap ve bulut senkronizasyonu](#hesap-ve-bulut-senkronizasyonu-opsiyonel)).
Bu, tek harici bağımlılık olan bir CDN betiği (`@supabase/supabase-js`) yükler —
yapılandırılmamışsa (veya CDN'e erişilemiyorsa) uygulama bunu hiç fark etmeden
tamamen yerel çalışmaya devam eder.

## Çalıştırma

`index.html` dosyasına çift tıkla. Hepsi bu.

Yerel bir sunucu tercih edersen:

```bash
python3 -m http.server 8000
```

Yayındaki sürüm GitHub Pages üzerinde, `main` dalının kökünden servis ediliyor
(`.nojekyll` dosyası Pages'in dosyaları olduğu gibi sunması için). `git push`
sonrası site birkaç dakika içinde kendini günceller.

## Ne yapıyor

### 1. Eşleştirme oyunu

Hedef sesi dinlersin, sonra kendi sesini dinlersin, kaydırıcıyla eşitlemeye
çalışırsın. **İki ses aynı anda çalmaz** — kararı kulağınla ve hafızanla
verirsin. Kaydırıcı Hz değil **cent** taşır (1 oktav = 1200 cent), çünkü perde
algısı logaritmiktir: 200 Hz'de 1 Hz kocaman, 4000 Hz'de hiçbir şeydir.

### Üç deneyim seviyesi

Oyun sayfasının en üstündeki üç düğme, **kuralları** değiştirir (aşamalar *neyi*
eşleştirdiğini belirler; bu eksen *nasıl* eşleştirdiğini):

| Seviye | Hedefi dinleme | Karar | Puan çarpanı |
|---|---|---|---|
| **Acemi** | süresiz, istediğin kadar | Kontrol Et! düğmesi | ×1.0 |
| **Deneyimli** | **tek kez, 3 saniye** | Kontrol Et! düğmesi | ×1.4 |
| **Uzman** | **tek kez, 2 saniye** | Benimkini Çal'dan sonra **kaydırıcıyı bıraktığın an** | ×2.0 |

Deneyimli ve Uzman'da hedef tonu süresi dolana kadar durdurulamaz — kesilebilir
olsaydı yanlışlıkla çift tıklama tek dinleme hakkını sıfır saniyede yakardı.

Uzman modu kulağının **anlık isabetini** ölçer: hedefi bir kez duyar, kendi
sesini açar, kaydırıcıyı bir noktaya getirip bırakırsın; bırakma anı karardır.
(Klavyeyle çalışıyorsan ayarını yap, `Enter` ile kesinleştir.)

İlerleme panelindeki eşleştirme hatası grafiği yalnızca **seçili seviyenin**
turlarını gösterir — Uzman'ın anlık isabeti ile Acemi'nin serbest ayarı aynı
grafikte karışırsa eğilim okunamaz hale gelir.

### Karar anı

**Kontrol Et!** son karardır. O anda üç şey olur:

1. Sapma cent cinsinden ölçülür ve puan kaydedilir,
2. Kaydırıcı kilitlenir (cevabı gördükten sonra düzeltme yok),
3. İki ses **birlikte** çalar — duyduğun vuru, aradaki farkın kendisidir.
   Vuru ne kadar yavaşsa o kadar yakınsın.

Bu birleşik seste vibrato otomatik kapanır: ±8 cent'lik bir vibrato, 3 cent'lik
bir hatanın vurusunu tümden örterdi.

**Üç aşama:**

| Aşama | Ad | Ne değişir | Menzil |
|---|---|---|---|
| 1 | Ayırt Etme | Serbest hedef ton | ±300 cent |
| 2 | Aralık | Hedef çalınmaz; kök ses verilir, istenen aralığı sen kurarsın | ±600 cent |
| 3 | Tuzaklar | Oktav hatası artık mümkün; hedef bazen farklı tınıda çalar | ±1200 cent |

Aşama 1'de menzil bilerek bir oktavdan dardır: yeni başlayan biri hedefin
2. harmoniğine kilitlenip oktav hatası yapamasın. O tuzak ancak Aşama 3'te
bilinçli olarak devreye girer.

Her aşamanın içinde 5 alt seviye var; "mükemmel" toleransı 25 cent'ten
5 cent'e iner ve **uyarlanır zorluk** performansına göre bunu kendi ayarlar.

### 2. Ayırt etme antrenmanı (JND)

İki ses arka arkaya çalar, hangisinin daha tiz olduğunu seçersin. Doğru
bildikçe fark daralır, yanıldıkça açılır (2-aşağı-1-yukarı merdiven, %70.7
doğruluk eşiğine yakınsar). Sonunda **fark eşiğin** cent cinsinden çıkar —
bu sayı düştükçe kulağın keskinleşiyor demektir.

Ölçek: eğitimsiz kulak tipik olarak 20–50 cent, eğitimli müzisyen 5–10 cent
ayırt eder. 250 / 1000 / 4000 Hz bantlarında ayrı ayrı ölçülebilir.

### 3. İşitme testi ve "işitme yaşı"

> **Bu tıbbi bir test değildir ve tanı koymaz.** Tarayıcı mutlak ses düzeyini
> bilemez (sistem sesi, kulaklık duyarlılığı, ortam gürültüsü bilinmiyor),
> dolayısıyla bu bir **odyogram değildir**. Ölçebildiği tek şey, rahat bir
> seviyede duyabildiğin en yüksek frekanstır. İşitmenle ilgili gerçek bir
> kaygın varsa odyoloğa görün.

Yaşa bağlı işitme kaybı (presbiakuzi) tiz uçtan başladığı için "işitme yaşı"
bu sayıdan türetilen kaba bir tahmindir.

Testin iki dürüstlük tedbiri var:

- **Tuzak denemeleri:** denemelerin bir kısmı sessizdir. Sessizde "duydum"
  diyen kullanıcının sonucu *güvenilmez* damgalanır. En az 4 sessiz deneme
  garanti edilir — kısa süren testlerde bile karar veri üstünde verilsin diye.
- **Rampalı kapılama:** tonlar 50 ms rampayla açılıp kapanır. 16 kHz'lik bir
  tonu sert kesmek geniş bantlı bir "tık" üretir; kullanıcı tonu duymadığı
  halde tıkı duyup "duydum" der.

Üst sınır donanımına göre kırpılır (`min(20 kHz, örnekleme hızı/2 − 1500)`).
Kulaklık şarttır: dizüstü hoparlörleri 15 kHz üstünü zaten basamaz.

### 4. İlerleme

Fark eşiğinin zaman içindeki seyri, son turlardaki eşleştirme hatası, frekans
bandına göre isabet oranın ve işitme testi geçmişin. Grafikler kütüphanesiz,
doğrudan canvas üzerine çizilir.

## Verilerin

Her şey senin tarayıcında, `localStorage` içinde (`frekansOyun.v1`) tutulur.
Tarayıcı verilerini temizlersen kaybolur, o yüzden Ayarlar'dan arada bir
**JSON olarak dışa aktar**. Giriş yapmazsan buraya kadarı hepsi — sunucuya
hiçbir şey gitmez.

## Hesap ve bulut senkronizasyonu (opsiyonel)

Sağ üstteki **Giriş Yap**'tan e-posta + şifre ile bir hesap açabilirsin.
Giriş yaptığında yerelde tuttuğun aynı ilerleme (`kayit` nesnesi — skorlar,
JND ölçümleri, işitme testi geçmişi, ayarlar) [Supabase](https://supabase.com)
üzerindeki `profiles` tablosuna, satır başına Row Level Security ile
(yalnızca `auth.uid() = id`) yedeklenir ve cihazlar arası senkronize olur.
Hem bu cihazda hem hesapta ilerleme varsa (örn. ilk kez farklı bir cihazdan
giriş yapıyorsan) hangisinin kullanılacağı sana sorulur — sessizce üzerine
yazılmaz.

Giriş yapmadan da uygulama önceki gibi birebir çalışır; bu bölüm tamamen
isteğe bağlıdır.

**Projeyi kendi Supabase hesabınla çalıştırmak istersen:**

1. [supabase.com](https://supabase.com)'da bir proje oluştur (ücretsiz katman
   yeterli).
2. Proje SQL Editor'ünde [`supabase/schema.sql`](supabase/schema.sql)
   dosyasının tamamını çalıştır — `profiles` tablosunu ve RLS kurallarını
   kurar.
3. Proje **Ayarlar → API**'den *Project URL* ve **anon / public** anahtarını
   kopyala (`service_role` anahtarını **asla** kullanma — o sunucu tarafı
   içindir).
4. `index.html` içinde `SUPABASE_URL` ve `SUPABASE_ANON_KEY` sabitlerini
   (dosyanın başlarında, "BULUT" yorumunun hemen altında) bu değerlerle
   doldur.
5. Supabase panelinde **Authentication → Providers → Email**'in açık
   olduğundan emin ol (varsayılan olarak açıktır). İstersen aynı sayfadan
   "Confirm email" zorunluluğunu kapatabilirsin — açıksa kayıt olan
   kullanıcı e-postasını onaylamadan giriş yapamaz.

`anon`/`public` anahtarı istemci tarafında görünmek üzere tasarlanmıştır
(erişim denetimi veritabanı tarafında RLS ile yapılır), bu yüzden `index.html`
içinde açıkça durması sorun değildir — herkese açık bir repoda bile.

## Klavye

| Tuş | İşlev |
|---|---|
| `←` `→` | ince ayar (1 cent) |
| `Shift` + `←` `→` | kaba ayar (10 cent) |
| `Boşluk` | hedefi çal |
| `B` | kendi sesini çal |
| `Enter` | kontrol et / yeniden dene (Uzman modunda klavye kararı) |

## Teknik notlar

- **Flüt tınısı** toplamsal sentezle üretilir (`PeriodicWave`): temel güçlü,
  2. harmonik zayıf, üstü hızla söner. Üstüne bandı frekansla birlikte hareket
  eden nefes gürültüsü ve 5 Hz / ±8 cent vibrato biner.
- **İşitme testinde saf sinüs** kullanılır — eşik ölçümünde tek ve bilinen bir
  frekans gerekir.
- Kaydırıcı hareket ederken frekans sıçratılmaz, ~30 ms glide ile gider; aksi
  halde fermuar gürültüsü çıkar.
- Çıkışta sabit bir `DynamicsCompressor` limiter var. Bu bir konfor değil
  güvenlik gereğidir: duyulmayan tiz tonların yüksekliğini kullanıcı
  yargılayamaz, tavanı donanım değil uygulama koyar.
- `AudioContext` ilk kullanıcı hareketinde doğar (otomatik oynatma politikası).

### Arayüz

Koyu tema üzerine hafif bir stüdyo donanımı dili: paneller rack ünitesi gibi
üstten pah ışığı alıp altta gölge bırakır, oluklar ve ekranlar panele gömülüdür,
sayısal okumalar LED gibi hafifçe parlar, butonlar basılınca içeri oturur.

Kaydırıcı bir mikser faderıdır: kanal panele oyulmuştur, başlık metal bir
kapaktır ve ortasından geçen yeşil çizgi okuma çizgisidir (yeşil = senin sesin,
renk kodu uygulamanın tamamında aynı). Faderın altındaki çentikli ölçek merkezi
işaretler. Sonuç kadranı da çentikli bir VU göstergesi gibi çizilir.

Tümü CSS gradyanı ve gölgesiyle yapılır — görsel dosya veya font dosyası
yoktur. `prefers-reduced-motion` altında animasyonlar durur, odak halkaları ve
kontrast korunur.

### Doğrulama

Saf fonksiyonlar (`centArasi`, `bantHesapla`, `isitmeYasi`, `enYakinNota`,
`turPuani`…) ve durum makineleri `window.__fo` üzerinden dışa verilir, böylece
tarayıcı konsolundan sınanabilir:

```js
__fo.centArasi(440, 880)      // 1200
__fo.isitmeYasi(18000)        // "20–29"
__fo.bantHesapla(25, 25).bant // "mukemmel"
```
