# Bengali Font Setup for Invoice PDF

To properly display Bengali text in the generated PDF invoices, follow these steps:

## Option 1: Download Font File (Recommended)

1. Download **Noto Sans Bengali Medium** font from Google Fonts:
   - Visit: https://fonts.google.com/noto/specimen/Noto+Sans+Bengali
   - Click "Download family"
   - Extract the ZIP file

2. Copy the file **NotoSansBengali-Regular.ttf** to:
   ```
   assets/fonts/NotoSansBengali-Regular.ttf
   ```

3. Run `flutter pub get` to update the project

4. Rebuild the app - Bengali text should now render correctly in PDFs

## Option 2: Alternative Font

You can also use other open-source Bengali fonts:
- **Noto Serif Bengali**: https://fonts.google.com/noto/specimen/Noto+Serif+Bengali
- **Mukta**: https://fonts.google.com/specimen/Mukta

## Verify Installation

After adding the font:
1. Create a new invoice with Bengali details
2. Generate and save the PDF
3. The "ভ্যাট চালান (মূসক-৬.৩)" header should display correctly

If the font is not found, the app will use a fallback (Courier) font, which may not display Bengali characters properly.

## File Structure
```
assets/
└── fonts/
    └── NotoSansBengali-Regular.ttf
```

That's it! Your invoices will now have proper Bengali text support.
